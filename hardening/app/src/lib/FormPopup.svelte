<script>
  import Input from "./Input.svelte";

  export let title
  export let name
  export let hardening
  export let errors
  export let closeCallback
  export let submitCallback
</script>

<div class="pop-up">
  <div class="close" on:click={closeCallback}>✖</div>
  <div class="box">
    <h3>{title}</h3>
    <form on:submit={submitCallback}>
      <Input
        label="Name"
        bind:value={name}
        error={errors.name}
      />
      <Input
        label="Hardening"
        bind:value={hardening}
        error={errors.hardening}
        type="textarea"
      />
      <button>Submit</button>
    </form>
  </div>
</div>

<style>
  .pop-up {
    width: 100%;
    min-height: 100vh;
    position: fixed;
    top: 0; left: 0;
    padding: 1rem;
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: rgba(0, 0, 0, .8);
    z-index: 100;
  }

  .close {
    position: absolute;
    top: 1rem; right: 2rem;
    color: var(--white);
    font-weight: bold;
    font-size: 1.5rem;
    text-shadow: var(--shadow);
    cursor: pointer;
  }

  .box {
    width: 100%;
    max-width: 1024px;
    padding: 1rem;
    border-radius: .25rem;
    background-color: var(--white);
    box-shadow: var(--shadow);
  }

  h3 {
    margin-bottom: 1rem;
  }

  button {
    color: var(--white);
    background-color: var(--primary);
    display: block;
    margin-left: auto;
    font-weight: bold;
  }

  button:hover {
    background-color: var(--dark-gray);
  }
</style>
