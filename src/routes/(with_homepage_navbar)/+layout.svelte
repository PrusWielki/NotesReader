<script lang="ts">
  import ThemePicker from '$lib/components/theme_picker/theme_picker.svelte';
</script>


<nav class="w-full fixed top-0 font-montserrat z-10 backdrop-blur-md bg-transparent">
  <div class="navbar max-w-screen-xl mx-auto px-4">
    <div class="navbar-start">
      <a href="/" class="btn btn-ghost text-xl font-normal">Notes Reader</a>
    </div>

    <div class="navbar-end gap-4">
<ThemePicker class=""/>
      <a
        href="/login"
        class="btn btn-outline btn-secondary btn-sm text-primary-content"
        >Login</a
      >
    </div>
  </div>
</nav>
<slot/>