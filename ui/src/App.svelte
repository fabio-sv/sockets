<script lang="ts">
  import ChatHeader from './lib/components/ChatHeader.svelte';
  import Glass from './lib/components/Glass.svelte';
  import MessageBar from './lib/components/MessageBar.svelte';
  import Rain from './lib/components/Rain.svelte';
  import MessageList from './lib/components/MessageList.svelte';
  import Notifications from './lib/components/Notifications.svelte';
</script>

<main>
  <Rain>
    <Glass />
  </Rain>

  <Notifications />

  <ChatHeader />
  <MessageList />
  <MessageBar />
</main>
