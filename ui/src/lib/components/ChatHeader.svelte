<script lang="ts">
  import svelteLogo from '../../assets/svelte.svg';

  export let icon: string = svelteLogo;
  export let title: string = 'Sockets';
</script>

<header
  class="flex justify-start items-center gap-x-4 sm:m-4 mb-4 p-2 bg-slate-100/20 shadow-lg sm:rounded-md"
>
  <div class="rounded-full p-1">
    <img src={icon} alt="icon" class="h-10 w-10" />
  </div>
  <p class="font-medium text-2xl text-gray-700 flex-grow">{title}</p>
</header>
