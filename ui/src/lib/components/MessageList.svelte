<script lang="ts">
  import { afterUpdate } from 'svelte';
  import Message from './Message.svelte';
  import { messages } from '../stores/messages';

  let container: HTMLElement;

  const scrollToBottom = async (node) => {
    node.scroll({ top: node.scrollHeight, behavior: 'smooth' });
  };

  afterUpdate(() => {
    if (container) {
      scrollToBottom(container);
    }
  });
</script>

<section bind:this={container} class="mx-4 max-h- max-h-[82vh] overflow-y-auto">
  {#each $messages as message, i (i)}
    <Message self={message.self} time={message.time}>{message.message}</Message>
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
