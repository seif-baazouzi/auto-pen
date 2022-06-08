<script>
  import AdminNavBar from "../../lib/AdminNavBar.svelte"
  import UpdateUsername from "$lib/UpdateUsername.svelte"
  import UpdatePassword from "$lib/UpdatePassword.svelte"

  let content = "username"
</script>

<svelte:head>
  <title>Settings</title>
</svelte:head>

<AdminNavBar page="settings" />
<div class="container">
  <div class="box">
    <div class="side-bar">
      <div class={`item ${content === "username" ? "active" : ""}`} on:click={() => content = "username"}>Update username</div>
      <div class={`item ${content === "password" ? "active" : ""}`} on:click={() => content = "password"}>Update password</div>
    </div>
    <div class="content">
      {#if content === "username"}
        <UpdateUsername />
      {:else}
        <UpdatePassword />
      {/if}
    </div>
  </div>
</div>

<style>
  .container {
    width: 100%;
    min-height: calc(100vh - 2.5rem);
    padding: 2rem;
    overflow: hidden;
  }

  .box {
    width: 100%;
    margin: 0 auto;
    max-width: 768px;
    display: flex;
    border-radius: .25rem;
    box-shadow: var(--shadow);
    background-color: var(--white);
  }

  .side-bar {
    width: 10rem;
    box-shadow: var(--shadow);
  }

  .side-bar .item {
    font-size: .75rem;
    font-weight: bold;
    padding: .5rem .75rem;
    border-bottom: .1rem solid var(--gray);
    cursor: pointer;
  }

  .side-bar .item.active, .side-bar .item.active:hover {
    background-color: var(--gray);
  }

  .side-bar .item:hover {
    background-color: var(--bg);
  }

  .content {
    flex: 1;
    padding: .75rem;
  }

  @media screen and (max-width: 480px) {
    .box {
      flex-direction: column;
    }

    .side-bar {
      width: 100%;
      display: flex;
    }

    .side-bar .item {
      flex: 1;
      text-align: center;
      text-overflow: ellipsis;
      white-space: nowrap;
      overflow: hidden;
    }
  }

</style>
