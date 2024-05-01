<script lang="ts">
  import { onMount } from "svelte";
  import socketsLogo from "../../assets/letter-s.svg";
  import QRCode from "qrcode";

  export let icon: string = socketsLogo;
  export let title: string = "Chit Chat";

  let dialog: HTMLDialogElement;
  let modalOpen = false;
  let canvas: HTMLCanvasElement;

  function toggleModal() {
    modalOpen ? dialog.close() : dialog.showModal();
    modalOpen = !modalOpen;
  }

  onMount(() => {
    QRCode.toCanvas(canvas, window.location.href, (error) => {
      if (error) console.error(error);
    });
  });
</script>

<header
  class="flex justify-start items-center gap-x-4 sm:m-4 mb-4 p-2 bg-slate-100/20 shadow-lg sm:rounded-md"
  on:click={toggleModal}
  on:keydown={toggleModal}
>
  <div class="rounded-full p-1">
    <div class="rounded-full p-1">
      <img src={icon} alt="icon" class="h-10 w-10" />
    </div>
  </div>
  <p class="font-medium text-2xl text-gray-700 flex-grow">{title}</p>
</header>

<dialog bind:this={dialog} class="pt-8 text-center rounded-lg">
  <p>Scan me!</p>
  <canvas bind:this={canvas} class="w-128 h-128 mx-auto"></canvas>

  <button
    on:click={toggleModal}
    class="w-full py-2 px-20 font-bold text-red border-t mt-4"
  >
    Close
  </button>
</dialog>
