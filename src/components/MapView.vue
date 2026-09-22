<script setup>
import { onMounted, onUnmounted, ref } from "vue";
import Panzoom from "@panzoom/panzoom";
import mapUrl from "../assets/BART_cc_map.png";

const viewport = ref(null);
const image = ref(null);
let panzoom = null;
let gestureStart = 1;
let pinchStart = 0;
let pinchScale = 1;
let clamping = false;
let lastTapAt = 0;
let lastTapX = 0;
let lastTapY = 0;
let ignoreTapUntil = 0;
let skipNextDoubleClick = false;

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

function eventPoint(event) {
  if (Number.isFinite(event.clientX) && Number.isFinite(event.clientY) && (event.clientX || event.clientY)) {
    return { clientX: event.clientX, clientY: event.clientY };
  }
  const box = viewport.value.getBoundingClientRect();
  return { clientX: box.left + box.width / 2, clientY: box.top + box.height / 2 };
}

function touchDistance(touches) {
  return Math.hypot(touches[0].clientX - touches[1].clientX, touches[0].clientY - touches[1].clientY);
}

function touchCenter(touches) {
  return {
    clientX: (touches[0].clientX + touches[1].clientX) / 2,
    clientY: (touches[0].clientY + touches[1].clientY) / 2,
  };
}

function toggleZoom(clientX, clientY) {
  if (!panzoom) {
    return;
  }
  if (panzoom.getScale() > 1.05) {
    panzoom.reset();
    return;
  }
  panzoom.zoomToPoint(2.5, { clientX, clientY });
}

function onWheel(event) {
  panzoom?.zoomWithWheel(event);
}

function onPointerUp(event) {
  if (!panzoom || pinchStart || performance.now() < ignoreTapUntil) {
    return;
  }
  if (event.isPrimary === false) {
    return;
  }
  const now = performance.now();
  const dx = event.clientX - lastTapX;
  const dy = event.clientY - lastTapY;
  if (now - lastTapAt < 350 && dx * dx + dy * dy < 576) {
    toggleZoom(event.clientX, event.clientY);
    lastTapAt = 0;
    skipNextDoubleClick = true;
    return;
  }
  lastTapAt = now;
  lastTapX = event.clientX;
  lastTapY = event.clientY;
}

function onDoubleClick(event) {
  if (skipNextDoubleClick) {
    skipNextDoubleClick = false;
    return;
  }
  toggleZoom(event.clientX, event.clientY);
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
  if (event.cancelable) {
    event.preventDefault();
  }
  if (event.type === "gesturestart") {
    gestureStart = panzoom.getScale();
    lastTapAt = 0;
    ignoreTapUntil = Number.POSITIVE_INFINITY;
    return;
  }
  if (event.type === "gestureend") {
    ignoreTapUntil = performance.now() + 400;
    return;
  }
  panzoom.zoomToPoint(gestureStart * event.scale, eventPoint(event));
}

function onTouchStart(event) {
  if (event.touches.length !== 2 || !panzoom) {
    return;
  }
  event.preventDefault();
  pinchStart = touchDistance(event.touches);
  pinchScale = panzoom.getScale();
  lastTapAt = 0;
  ignoreTapUntil = Number.POSITIVE_INFINITY;
}

function onTouchMove(event) {
  if (event.touches.length !== 2 || !pinchStart || !panzoom) {
    return;
  }
  event.preventDefault();
  panzoom.zoomToPoint(pinchScale * (touchDistance(event.touches) / pinchStart), touchCenter(event.touches));
}

function onTouchEnd(event) {
  if (event.touches.length >= 2) {
    return;
  }
  pinchStart = 0;
  ignoreTapUntil = performance.now() + 400;
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
    pinchAndPan: true,
    cursor: "grab",
  });
  const node = viewport.value;
  const gestureOpts = { capture: true, passive: false };
  node.addEventListener("wheel", onWheel, { passive: false });
  node.addEventListener("pointerup", onPointerUp);
  node.addEventListener("dblclick", onDoubleClick);
  node.addEventListener("touchstart", onTouchStart, { passive: false });
  node.addEventListener("touchmove", onTouchMove, { passive: false });
  node.addEventListener("touchend", onTouchEnd);
  node.addEventListener("touchcancel", onTouchEnd);
  image.value.addEventListener("panzoomchange", onPanzoomChange);
  window.addEventListener("gesturestart", onGesture, gestureOpts);
  window.addEventListener("gesturechange", onGesture, gestureOpts);
  window.addEventListener("gestureend", onGesture, gestureOpts);
  document.addEventListener("keydown", onKeydown);
});

onUnmounted(() => {
  const node = viewport.value;
  const gestureOpts = { capture: true };
  node?.removeEventListener("wheel", onWheel);
  node?.removeEventListener("pointerup", onPointerUp);
  node?.removeEventListener("dblclick", onDoubleClick);
  node?.removeEventListener("touchstart", onTouchStart);
  node?.removeEventListener("touchmove", onTouchMove);
  node?.removeEventListener("touchend", onTouchEnd);
  node?.removeEventListener("touchcancel", onTouchEnd);
  image.value?.removeEventListener("panzoomchange", onPanzoomChange);
  window.removeEventListener("gesturestart", onGesture, gestureOpts);
  window.removeEventListener("gesturechange", onGesture, gestureOpts);
  window.removeEventListener("gestureend", onGesture, gestureOpts);
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
