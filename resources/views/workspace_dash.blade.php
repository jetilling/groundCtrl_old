@extends('layouts.app')

@section('content')
<section class="light-background" style="padding-top: 50px;">
  <div class="columns is-centered">
    <h1 class="title">{{ $workspace->name }}</h1>
  </div>
  <div class="columns is-centered">
    <p>{{ $workspace->description }}</p>
  </div>

  <div class="tile is-ancestor is-75vh">

    <div class="tile is-parent">
      <article class="tile is-child notification dark-tile">
        <p class="title white-text">Tasks</p>
      </article>
    </div>

    <div class="tile is-parent">
      <article class="tile is-child notification dark-tile">
        <p class="title white-text">Notes</p>
      </article>
    </div>
      
    <div class="tile is-parent">
      <article class="tile is-child notification lightblue-tile">
        <!-- ELM INJECTION -->
        <div id="elm-tabs"></div>
        <script src="{{ asset('js/tabs.js') }}"></script>
        <script>
          let tabData = []
          @foreach ($workspace->tabs as $tab)
            tabData.push({
              id: "{{ $tab->id }}",
              name: "{{ $tab->name }}",
              url: "{{ $tab->url }}"
            })
          @endforeach
          let app = Elm.Tabs.init({
            node: document.getElementById("elm-tabs"), 
            flags: { 
              tabs: tabData,
              workspaceId: {{ $workspace->id }},
              csrfToken: "{{ csrf_token() }}"
            }
          })
          
          let tabs = []
          app.ports.openTabs.subscribe(function(data) {
            data.forEach(function(tab) {
              tabs.push(window.open(tab.url, '_blank'))
            })
            localStorage.setItem("{{ $workspace->name }}TabsOpen", true)
          });

          app.ports.closeTabs.subscribe(function(data) {
            tabs.forEach(function(tab){
              tab.close()
            })
            localStorage.removeItem("{{ $workspace->name }}TabsOpen")
          });

          window.onbeforeunload = function(event) { 
            let tabsOpen = localStorage.getItem("{{ $workspace->name }}TabsOpen")
            if (tabsOpen) {
              return confirm()
            }
          };

        </script>
      </article>
    </div>

  </div>

</section>
@endsection