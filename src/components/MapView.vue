<script setup>
import { onMounted, onUnmounted, ref } from "vue";
import Panzoom from "@panzoom/panzoom";
import mapUrl from "../assets/BART_cc_map.png";

const viewport = ref(null);
const image = ref(null);
let panzoom = null;
let gestureStart = 1;
let clamping = false;

function clampPan(x, y, scale) {
  if (scale <= 1.001) {
    return { x: 0, y: 0 };
  }

  const clampAxis = (pos, imgSize, viewSize) => {
    const scaled = imgSize * scale;
    const originShift = (imgSize - scaled) / 2;
    const minEdge = Math.min(0, viewSize - scaled);
    const maxEdge = Math.max(0, viewSize - scaled);
    const minPos = (minEdge - originShift) / scale;
    const maxPos = (maxEdge - originShift) / scale;
    return Math.min(Math.max(pos, minPos), maxPos);
  };

  return {
    x: clampAxis(x, image.value.offsetWidth, viewport.value.clientWidth),
    y: clampAxis(y, image.value.offsetHeight, viewport.value.clientHeight),
  };
}

function onWheel(event) {
  panzoom?.zoomWithWheel(event);
}

function onDoubleClick(event) {
  if (!panzoom) {
    return;
  }
  if (panzoom.getScale() > 1) {
    panzoom.reset();
    return;
  }
  panzoom.zoomToPoint(2.5, { clientX: event.clientX, clientY: event.clientY });
}

function onPanzoomChange(event) {
  if (!panzoom || clamping) {
    return;
  }
  const { x, y, scale } = event.detail;
  const next = clampPan(x, y, scale);
  if (Math.abs(next.x - x) < 0.01 && Math.abs(next.y - y) < 0.01) {
    return;
  }
  clamping = true;
  panzoom.pan(next.x, next.y, { animate: false, force: true, silent: true });
  clamping = false;
}

function onGesture(event) {
  if (!panzoom) {
    return;
  }
  event.preventDefault();
  if (event.type === "gesturestart") {
    gestureStart = panzoom.getScale();
    return;
  }
  panzoom.zoomToPoint(gestureStart * event.scale, {
    clientX: event.clientX,
    clientY: event.clientY,
  });
}

function onKeydown(event) {
  if (!panzoom || !(event.metaKey || event.ctrlKey)) {
    return;
  }
  if (event.key === "=" || event.key === "+") {
    event.preventDefault();
    panzoom.zoomIn();
  } else if (event.key === "-") {
    event.preventDefault();
    panzoom.zoomOut();
  } else if (event.key === "0") {
    event.preventDefault();
    panzoom.reset();
  }
}

onMounted(() => {
  panzoom = Panzoom(image.value, {
    minScale: 1,
    maxScale: 8,
    canvas: true,
    panOnlyWhenZoomed: true,
    cursor: "grab",
  });
  viewport.value.addEventListener("wheel", onWheel);
  image.value.addEventListener("dblclick", onDoubleClick);
  image.value.addEventListener("panzoomchange", onPanzoomChange);
  document.addEventListener("gesturestart", onGesture, { capture: true });
  document.addEventListener("gesturechange", onGesture, { capture: true });
  document.addEventListener("keydown", onKeydown);
});

onUnmounted(() => {
  viewport.value?.removeEventListener("wheel", onWheel);
  image.value?.removeEventListener("dblclick", onDoubleClick);
  image.value?.removeEventListener("panzoomchange", onPanzoomChange);
  document.removeEventListener("gesturestart", onGesture, { capture: true });
  document.removeEventListener("gesturechange", onGesture, { capture: true });
  document.removeEventListener("keydown", onKeydown);
  panzoom?.destroy();
  panzoom = null;
});
</script>

<template>
  <section class="page map-page">
    <div ref="viewport" class="map-viewport">
      <img ref="image" class="map-image" :src="mapUrl" alt="BART system map" />
    </div>
  </section>
</template>
