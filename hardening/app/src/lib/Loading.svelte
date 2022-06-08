<div class="loading">
  <div class="container">
    <div class="fly">
      <div class="body">
        <div class="line line1"></div>
        <div class="line line2"></div>
        <div class="line line3"></div>
        <div class="line line4"></div>
      </div>
    </div>
    <h3>LOADING</h3>
  </div>
</div>

<style>
  .loading {
    width: 100%;
    height: 100vh;
    position: fixed;
    top: 0; left: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: var(--bg);
  }

  .container {
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .fly {
    margin-bottom: 1.5rem;
  }

  .fly .body {
    width: 10rem;
    height: 2rem;
    position: relative;
    border-radius: .125rem;
    border-top-right-radius: 1rem;
    background-color: var(--black);
    animation: body-anim 1s infinite;
  }

  .fly .body .line {
    position: absolute;
    background-color: var(--black);
  }

  .fly .body .line1 {
    width: 30%;
    height: 2%;
    top: 10%;
    animation: line-anim .4s infinite;
  }

  .fly .body .line2 {
    width: 20%;
    height: 2%;
    top: 30%;
    animation: line-anim .4s .75s infinite;
  }

  .fly .body .line3 {
    width: 25%;
    height: 2%;
    top: 80%;
    animation: line-anim .4s .25s infinite;
  }

  .fly .body .line4 {
    width: 10%;
    height: 2%;
    top: 50%;
    animation: line-anim .4s .5s infinite;
  }

  @keyframes body-anim {
    0%, 100% {
      transform: rotateZ(0) translateY(0);
    }

    50% {
      transform: rotateZ(-1deg) translateY(10%);
    }
  }

  @keyframes line-anim {
    from {
      left: 50%;
      opacity: 1;
    }

    to {
      left: -80%;
      opacity: 0;
    }
  }

  .container h3 {
    font-size: .75rem;
    letter-spacing: .25em;
    color: var(--dark-gray)
  }
</style>
