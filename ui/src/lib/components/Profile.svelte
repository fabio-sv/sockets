<script lang="ts">
  import svelteLogo from '../../assets/svelte.svg';

  export let name: string = 'user';
  export let icon: string = svelteLogo;
</script>

<p class="text-xs text-gray-700">
  Signed in as: <mark class="bg-transparent font-mono text-xl">{name}</mark>
</p>
