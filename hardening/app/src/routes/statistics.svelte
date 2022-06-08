<script>
  import { onMount } from "svelte"
  import { goto } from "$app/navigation"

  import Loading from "../lib/Loading.svelte"
  import UserNavBar from "../lib/UserNavBar.svelte"

  import { api } from "$lib/config.js"

  let maxCount = null
  let statistics = null

  onMount(async () => {
    let res = await fetch(`${api}/user/statistics`, {
      headers: {
        "X-Token": localStorage.getItem("token")
      }
    })
    res = await res.json()

    if(res.message === "invalid-token") {
      return goto("/login")
    }

    statistics = res.data
    maxCount = res.data[0].count
    minCount = res.data[res.data[res.data.length-1]].count
  })

  const colors = {
    start: {
      red: 70,
      green: 201,
      blue: 231
    },
    end: {
      red: 70,
      green: 96,
      blue: 231
    }
  }

  function colorGradient(fadeFraction, rgbColor1, rgbColor2, rgbColor3) {
    var color1 = rgbColor1;
    var color2 = rgbColor2;
    var fade = fadeFraction;

    // Do we have 3 colors for the gradient? Need to adjust the params.
    if (rgbColor3) {
      fade = fade * 2;

      // Find which interval to use and adjust the fade percentage
      if (fade >= 1) {
        fade -= 1;
        color1 = rgbColor2;
        color2 = rgbColor3;
      }
    }

    var diffRed = color2.red - color1.red;
    var diffGreen = color2.green - color1.green;
    var diffBlue = color2.blue - color1.blue;

    var gradient = {
      red: parseInt(Math.floor(color1.red + (diffRed * fade)), 10),
      green: parseInt(Math.floor(color1.green + (diffGreen * fade)), 10),
      blue: parseInt(Math.floor(color1.blue + (diffBlue * fade)), 10),
    };

    return 'rgb(' + gradient.red + ',' + gradient.green + ',' + gradient.blue + ')';
  }

  function getStyles(count) {
    const percentage = (count*100)/maxCount
     
    return `width: ${percentage}%; background-color: ${colorGradient(percentage/100, colors.start, colors.end)}`
  }

</script>

<svelte:head>
  <title>Statistics</title>
</svelte:head>

{#if statistics != null}
  <UserNavBar page="statistics" />
  <div class="container">
    {#if statistics.length == 0}
      <h1 class="msg">There is no statistics yet!</h1>
    {:else}
      <div class="list">
        {#each statistics as s}
          <div class="item">
            <p>{s.technologie}</p>
            <div class="statistic">
              <span class="color" style={getStyles(s.count)}></span>
              <span class="count">{s.count}</span>
            </div>
          </div>
        {/each}
      </div>
    {/if}
  </div>
{:else}
  <Loading />
{/if}

<style>
  .container {
    width: 100%;
    max-width: 1024px;
    margin: 0 auto;
    padding: 1rem;
  }

  h1.msg {
    font-size: 2rem;
    text-align: center;
    padding: 2rem 1rem;
  }

  .list .item {
    display: flex;
    align-items: center;
    margin-bottom: .25rem;
  }

  .item p {
    flex: 1;
    font-size: .75rem;
    text-align: right;
    padding-right: .25rem;
    color: var(--dark-gray);
    text-transform: capitalize;
  }

  .item .statistic {
    flex: 4;
    display: flex;
    align-items: center;
    overflow: hidden;
    border-radius: .2rem;
  }

  .item .statistic .color {
    height: 1rem;
    display: block;
    margin-right: .5rem;
    border-radius: .125rem;
    background-color: #37406a;
    animation: progress .75s ease-out;
  }

  .item .statistic .count {
    opacity: .75;
    font-size: .5rem;
    color: var(--dark-gray);
  }

  @keyframes progress {
    from {
      width: 0;
    }

    to {
      width: attr(width);
    }
  }
</style>