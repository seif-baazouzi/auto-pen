<script>
  let hide = true;

  export let page
  export let home
  export let links
  export let logoutCallBack
</script>

<nav>
  <div class="container">
    <a
      href={home}
      class="logo"
      >AutoPen
      <span class="pipe">|</span>
      <span class="word">hardening</span>
    </a>
    <ul class={hide ? "hide" : ""}>
      {#each links as link}
        <li>
          <a href={link.href}
            on:click={() => hide = true}
            class={page == link.page ? "active" : ""}
            >{link.content}
          </a>
        </li>
      {/each}
      <li>
        <button class="btn" on:click={logoutCallBack}>Logout</button>
      </li>
    </ul>

    <div class={`burger ${!hide ? "x" : ""}`} on:click={() => hide = !hide}>
      <div></div>
      <div></div>
      <div></div>
    </div>
  </div>
</nav>

<style>
  nav {
    box-shadow: var(--shadow);
    background-color: var(--white);
    position: sticky;
    top: 0; left: 0;
    z-index: 10;
  }

  .container {
    width: 100%;
    max-width: var(--max-width);
    padding: 0 1rem;
    margin: 0 auto;
    height: 2.5rem;
    display: flex;
    align-items: center;
    justify-content: space-between;
  }

  .logo {
    color: var(--black);
    font-size: 1.2rem;
    font-weight: bold;
    display: flex;
    align-items: center;
  }

  .logo .pipe {
    color: var(--gray);
    margin: 0 .25rem;
    font-size: 1rem;
  }

  .logo .word {
    opacity: .5;
    font-size: .75rem;
    color: var(--black);
    transition: .3s ease-out;
  }

  .logo:hover .word {
    opacity: 1;
    color: var(--primary);
  }

  ul {
    display: flex;
    align-items: center;
    justify-content: space-between;
  }

  li {
    list-style: none;
    padding-right: .75rem;
  }

  li:last-child {
    padding-right: 0;
  }

  ul :global(a) {
    display: block;
    font-size: .6rem;
    color: var(--dark-gray);
    transition: opacity .1s ease-in;
    opacity: .7;
  }

  ul :global(a.active) {
    opacity: 1;
    color: var(--primary);
  }

  ul :global(a:hover) {
    opacity: 1;
  }

  nav .btn {
    color: var(--white);
    display: block;
    font-size: .5rem;
    font-weight: bold;
    margin-left: .5rem;
    border-radius: 1em;
    padding: .75em 1.5em;
    background-color: var(--primary);
    transition: background .3s ease-in;
    cursor: pointer;
  }

  nav .btn:hover {
    background-color: var(--dark-gray);
  }
  
  .burger {
    width: 1rem;
    display: none;
    cursor: pointer;
  }

  .burger div {
    width: 100%;
    height: .125rem;
    margin: .1rem 0;
    background-color: var(--dark-gray);
    transition: .3s;
  }

  .burger.x div:nth-child(1) {
    transform: rotate(45deg) translate(.25rem, .125rem);
  }

  .burger.x div:nth-child(2) {
    opacity: 0;
  }

  .burger.x div:nth-child(3) {
    transform: rotate(-45deg) translate(.25rem, -.125rem);
  }

  @media screen and (max-width: 768px) {
    ul {
      width: 100%;
      padding: 1rem 0;
      position: absolute;
      top: 3rem; left: 0;
      flex-direction: column;
      background-color: var(--white);
      transition: top .3s ease-in;
    }

    li {
      padding: 0;
      width: 100%;
    }

    ul :global(a) {
      width: 100%;
      padding: .75rem 0;
      text-align: center;
    }

    ul :global(a:hover) {
      background-color: var(--bg);
    }

    ul.hide {
      top: -120vh;
    }

    nav .btn {
      width: 100%;
      margin-left: 0;
      margin-bottom: 1rem;
      border-radius: 0;
    }

    .burger {
      display: block;
    }
  }
</style>
