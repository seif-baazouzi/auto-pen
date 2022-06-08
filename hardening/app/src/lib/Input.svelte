<script>
  export let label
  export let value = ""
  export let error = null
  export let type = "text"
</script>

<div class="input">
  <label for={label}>{label}</label>
  {#if type === "password"}
    <input type="password" id={label} bind:value={value}>
  {:else if type === "textarea"}
    <textarea id={label} bind:value={value}></textarea>
  {:else}
    <input type="text" id={label} bind:value={value}>
  {/if}
  <span>{error ? error : ""}</span>
</div>

<style>
  .input {
    width: 100%;
    margin-bottom: 1rem;
  }

  label, input, textarea {
    width: 100%;
    display: block;
  }

  label {
    color: var(--dark-gray);
    font-size: .6rem;
    font-weight: bold;
  }

  input, textarea {
    font-size: .7rem;
    padding: .5em;
    border-radius: .25em;
    border: .075em solid var(--gray);
    background-color: var(--bg);
    transition: border .1s ease-in;
  }

  input:focus, textarea:focus {
    border: .075em solid var(primary);
  }

  textarea {
    height: 10rem;
    resize: none;
  }

  span {
    display: block;
    font-size: .5rem;
    font-weight: bold;
    margin-top: .25em;
    color: var(--error);
  }

  label, span {
    margin-left: .25rem;
  }
</style>
