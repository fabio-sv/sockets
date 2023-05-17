<script lang="ts">
  let dropletCount = 25;

  function random(min = 0, max = 100) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }

  function randomDelay() {
    return Math.random() * 4;
  }

  function randomSpeed() {
    return Math.random() * 3 + 2;
  }

  $: drops = [...Array(dropletCount).keys()];
</script>

<div class="bg-slate-100">
  {#each drops as drop, i (i)}
    <svg
      width="1%"
      viewbox="0 0 30 30"
      style={`left: ${random()}%; animation-duration: ${randomSpeed()}s; animation-delay: ${randomDelay()}s `}
    >
      <path
        fill="transparent"
        stroke="#00b2ffdd"
        stroke-width="1"
        d="M15 3
					Q16.5 6.8 25 18
					A12.8 12.8 0 1 1 5 18
					Q13.5 6.8 15 3z"
      />
    </svg>
  {/each}

  <slot />
</div>

<style>
  div {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100vh;
    overflow: hidden;
    z-index: -1;
  }

  svg {
    position: absolute;
    top: -2rem;
    height: 2rem;
    width: 0.5rem;

    animation: rain 3s linear 2s infinite;
  }

  @keyframes rain {
    from {
      top: -2rem;
    }
    to {
      top: 100vh;
    }
  }
</style>
