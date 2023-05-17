<script lang="ts">
  import classNames from 'classnames';
  import Time from './Time.svelte';

  export let self: boolean = false;
  export let time: Date;

  $: timeString = time.toLocaleTimeString(['en-US'], {
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
  });

  $: sectionClass = classNames(
    'flex w-full mb-2 items-end gap-x-1 justify-end',
    self ? 'flex-row' : 'flex-row-reverse'
  );

  $: textClass = classNames(
    'text-sm px-6 py-2 rounded-md w-fit max-w-3xl shadow-sm',
    self ? 'bg-red/80 text-white' : 'bg-slate-200/50 text-gray-700'
  );
</script>

<section class={sectionClass}>
  <Time>{timeString}</Time>
  <p class={textClass}><slot /></p>
</section>
