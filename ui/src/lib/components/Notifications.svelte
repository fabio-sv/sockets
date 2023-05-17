<script lang="ts">
  import type { INotification } from '../types';
  import { notifications } from '../stores/notifications';
  import Notification from './Notification.svelte';

  let showNotification = false;
  let notification: INotification;

  $: {
    notification = $notifications.slice(-1).pop();
    showNotification = true;

    setTimeout(() => {
      showNotification = false;
    }, 5000);
  }
</script>

{#if showNotification && notification}
  <Notification type={notification.type}>{notification.message}</Notification>
{/if}
