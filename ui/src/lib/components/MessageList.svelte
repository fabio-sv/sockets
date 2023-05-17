<script lang="ts">
  import { afterUpdate } from 'svelte';
  import type { IMessage, INotification } from '../types';
  import Message from './Message.svelte';
  import Information from './Information.svelte';
  import { messages } from '../stores/messages';
  import { notifications } from '../stores/notifications';

  let container: HTMLElement;
  let sortedByTime: (IMessage | INotification)[] = [];

  const scrollToBottom = async (node) => {
    node.scroll({ top: node.scrollHeight, behavior: 'smooth' });
  };

  afterUpdate(() => {
    if (container) {
      scrollToBottom(container);
    }
  });

  $: {
    sortedByTime = [...$messages, ...$notifications].sort((a, b) =>
      a.time > b.time ? 1 : a.time < b.time ? -1 : 0
    );
  }
</script>

<section bind:this={container} class="mx-4 max-h- max-h-[82vh] overflow-y-auto">
  {#each sortedByTime as chatItem, i (i)}
    {#if 'from' in chatItem}
      <Message self={chatItem.self} time={chatItem.time}>
        {chatItem.message}
      </Message>
    {:else}
      <Information time={chatItem.time} message={chatItem.message} />
    {/if}
  {/each}
</section>

<style>
  section {
    -ms-overflow-style: none;
    scrollbar-width: none;
  }

  section::-webkit-scrollbar {
    display: none;
  }
</style>
