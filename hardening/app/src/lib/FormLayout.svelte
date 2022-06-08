<script>
  export let title
  export let button
  export let submit
  export let link = null
</script>

<div class="container">
  <form on:submit={submit}>
    <h1>{title}</h1>
    <slot />
    <button type="submit">{button}</button>
    
    {#if link}
      <div class="link">{link.prefix} <a href={link.href}>{link.content}</a></div>
    {/if}
  </form>
</div>

<style>
  .container {
    width: 100%;
    min-height: 100vh;
    padding: 1rem;
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: #fbfbfb;
  }

  h1 {
    margin-bottom: 2rem;
  }

  form {
    width: 100%;
    max-width: 400px;
    padding: 1.5rem 1rem;
    border-radius: .25rem;
    background-color: var(--white);
    box-shadow: var(--shadow);
  }

  h1 {
    font-size: 1.6rem;
    text-align: center;
  }

  button {
    width: 100%;
    color: var(--white);
    font-size: .6rem;
    font-weight: bold;
    border-radius: 1em;
    padding: .75em 1.5em;
    background-color: var(--primary);
    transition: background .3s ease-in;
    cursor: pointer;
  }

  button:hover {
    background-color: var(--dark-gray);
  }

  .link {
  margin-top: 1rem;
  font-size: .6rem;
  text-align: center;
}

  .link :global(a) {
    font-weight: bold;
    color: var(--primary);
  }

  .link :global(a:hover) {
    color: var(--dark-gray);
  }
</style>
