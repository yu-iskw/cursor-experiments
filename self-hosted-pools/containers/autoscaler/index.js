"use strict";

const { GoogleAuth } = require("google-auth-library");

const CURSOR_API_BASE = process.env.CURSOR_API_BASE || "https://api.cursor.com";
const PROJECT_ID = requiredEnv("GOOGLE_CLOUD_PROJECT");
const LOCATION = requiredEnv("CLOUD_RUN_LOCATION");
const WORKER_POOL_NAME = requiredEnv("WORKER_POOL_NAME");
const CURSOR_API_KEY = requiredEnv("CURSOR_API_KEY");

const TARGET_UTILIZATION = parseFloat(process.env.TARGET_UTILIZATION || "0.5");
const MIN_INSTANCES = parseInt(process.env.MIN_INSTANCES || "1", 10);
const MAX_INSTANCES = parseInt(process.env.MAX_INSTANCES || "10", 10);
const POLLING_INTERVAL_MS = parseInt(process.env.POLLING_INTERVAL_MS || "30000", 10);
const SCALE_DOWN_IDLE_POLLS = parseInt(process.env.SCALE_DOWN_IDLE_POLLS || "2", 10);

let lastKnownCount = null;
let consecutiveIdlePolls = 0;
let backoffMs = POLLING_INTERVAL_MS;

function requiredEnv(name) {
  const value = process.env[name];
  if (!value) {
    throw new Error(`Missing required environment variable: ${name}`);
  }
  return value;
}

function clamp(value, min, max) {
  return Math.min(max, Math.max(min, value));
}

function workerPoolPath() {
  return `projects/${PROJECT_ID}/locations/${LOCATION}/workerPools/${WORKER_POOL_NAME}`;
}

async function getGoogleAccessToken() {
  const auth = new GoogleAuth({
    scopes: ["https://www.googleapis.com/auth/cloud-platform"],
  });
  const client = await auth.getClient();
  const token = await client.getAccessToken();
  if (!token.token) {
    throw new Error("Failed to obtain Google Cloud access token");
  }
  return token.token;
}

async function fetchFleetSummary() {
  const response = await fetch(`${CURSOR_API_BASE}/v0/private-workers/summary`, {
    headers: {
      Authorization: `Bearer ${CURSOR_API_KEY}`,
      Accept: "application/json",
    },
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(`Cursor fleet API ${response.status}: ${body}`);
  }

  return response.json();
}

function extractCounts(summary) {
  const stats = summary.teamSummary || summary.userSummary || {};
  const inUse = Number(stats.inUse ?? 0);
  const totalConnected = Number(stats.totalConnected ?? 0);
  return { inUse, totalConnected };
}

function computeDesiredInstances(inUse, totalConnected) {
  if (!Number.isFinite(TARGET_UTILIZATION) || TARGET_UTILIZATION <= 0) {
    throw new Error("TARGET_UTILIZATION must be a positive number");
  }

  let desired = Math.ceil(inUse / TARGET_UTILIZATION);
  if (inUse === 0 && totalConnected === 0) {
    desired = MIN_INSTANCES;
  }

  desired = clamp(desired, MIN_INSTANCES, MAX_INSTANCES);

  if (inUse === 0 && totalConnected > MIN_INSTANCES) {
    consecutiveIdlePolls += 1;
    if (consecutiveIdlePolls < SCALE_DOWN_IDLE_POLLS) {
      return totalConnected;
    }
  } else {
    consecutiveIdlePolls = 0;
  }

  return desired;
}

async function updateWorkerPoolInstanceCount(instanceCount) {
  const accessToken = await getGoogleAccessToken();
  const url = new URL(
    `https://run.googleapis.com/v2/${workerPoolPath()}?updateMask=scaling.manualInstanceCount`,
  );

  const response = await fetch(url, {
    method: "PATCH",
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      scaling: {
        manualInstanceCount: instanceCount,
      },
    }),
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(`Cloud Run PATCH ${response.status}: ${body}`);
  }

  return response.json();
}

async function reconcile() {
  const summary = await fetchFleetSummary();
  const { inUse, totalConnected } = extractCounts(summary);
  const desired = computeDesiredInstances(inUse, totalConnected);

  if (lastKnownCount === desired) {
    console.log(
      JSON.stringify({
        event: "reconcile_skip",
        inUse,
        totalConnected,
        desired,
      }),
    );
    backoffMs = POLLING_INTERVAL_MS;
    return;
  }

  console.log(
    JSON.stringify({
      event: "reconcile_apply",
      inUse,
      totalConnected,
      from: lastKnownCount,
      to: desired,
    }),
  );

  await updateWorkerPoolInstanceCount(desired);
  lastKnownCount = desired;
  backoffMs = POLLING_INTERVAL_MS;
}

async function sleep(ms) {
  await new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
  console.log(
    JSON.stringify({
      event: "autoscaler_start",
      workerPool: WORKER_POOL_NAME,
      location: LOCATION,
      min: MIN_INSTANCES,
      max: MAX_INSTANCES,
      targetUtilization: TARGET_UTILIZATION,
      pollMs: POLLING_INTERVAL_MS,
    }),
  );

  while (true) {
    try {
      await reconcile();
    } catch (error) {
      console.error(
        JSON.stringify({
          event: "reconcile_error",
          message: error.message,
        }),
      );
      backoffMs = Math.min(backoffMs * 2, POLLING_INTERVAL_MS * 8);
    }

    await sleep(backoffMs);
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
