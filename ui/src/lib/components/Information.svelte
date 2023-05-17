<script lang="ts">
  import { formatTime } from '../utils/time';
  import Time from './Time.svelte';

  export let time: Date = new Date();
  export let message = 'unused';
</script>

<div class="flex justify-start items-center gap-x-2 w-fit mx-auto mt-1 mb-2">
  <Time>{formatTime(time)}</Time>
  <p class="text-xs text-gray-600">{message}</p>
</div>
