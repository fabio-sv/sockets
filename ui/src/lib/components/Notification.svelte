<script lang="ts">
  import { fly } from 'svelte/transition';
  import classNames from 'classnames';
  import type { Type } from '../types/notification';

  export let type: Type = 'good';

  const classes = classNames(
    'fixed top-4 right-[50%] translate-x-[50%] sm:translate-x-0 sm:right-6 px-6 py-1',
    'bg-black/60 text-white rounded-sm text-xs shadow-lg sm:max-w-3xl sm:w-auto text-center',
    {
      'bg-red/80': type === 'good',
      'bg-warning-red/70': type === 'bad',
    }
  );
</script>

<aside class={classes} transition:fly={{ y: -50 }}>
  <slot />
</aside>
