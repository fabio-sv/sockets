<script lang="ts">
  import { sendMesssage } from '../stores/messages';
  import send from '../../assets/send.svg';

  let value = '';
  let textArea: HTMLTextAreaElement;

  const submit = () => {
    if (!value) {
      return;
    }

    sendMesssage(value);

    value = '';
    textArea.focus();

    setTimeout(() => {
      textAreaAdjust();
    }, 1);
  };

  const keyPressed = (e) => {
    if (e.code === 'Enter') {
      submit();
    }
  };

  const textAreaAdjust = () => {
    textArea.style.height = 'auto';
    textArea.style.height = `${textArea.scrollHeight}px`;
  };

  $: {
    if (value === '\n') {
      value = '';
    }
  }
</script>

<form on:submit|preventDefault={submit}>
  <footer class="flex items-end absolute bottom-0 w-full p-4">
    <label for="input" class="hidden" />
    <textarea
      name="input"
      bind:this={textArea}
      bind:value
      on:input={textAreaAdjust}
      on:keypress={keyPressed}
      rows="1"
      class="flex-grow bg-gray-200/90 text-gray-900 font-md outline-none px-4 mr-2 rounded-3xl resize-none py-[0.4rem] shadow-sm min-h-6"
    />
    <button
      type="submit"
      class="bg-[#00b2ff] text-white text-lg rounded-full shadow-2xl h-10 w-10 font-semibold"
    >
      <img src={send} alt="send" class="h-6 m-auto translate-x-[0.1rem]" />
    </button>
  </footer>
</form>
