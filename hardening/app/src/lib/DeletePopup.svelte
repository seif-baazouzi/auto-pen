<script>
  export let closeCallback
  export let deleteCallback
</script>

<div class="pop-up">
  <div class="close" on:click={closeCallback}>✖</div>
  <div class="box">
    <h3>Are you share you want to delete this!</h3>
    <div class="buttons">
      <button on:click={closeCallback}>Cancel</button>
      <button class="delete" on:click={deleteCallback}>Delete</button>
    </div>
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
    max-width: 500px;
    padding: 1rem;
    border-radius: .25rem;
    background-color: var(--white);
    box-shadow: var(--shadow);
  }

  h3 {
    margin-bottom: 1rem;
  }

  .buttons {
    display: flex;
    justify-content: flex-end;
  }

  button.delete {
    color: var(--white);
    margin-left: .25rem;
    background-color: var(--error);
  }

  button.delete:hover {
    background-color: var(--dark-gray);
  }
</style>
