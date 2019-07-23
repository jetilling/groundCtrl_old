@extends('layouts.app')

@section('content')
<section class="light-background" style="padding-top: 50px;">
  <!-- <div class="columns is-centered">
    <h1 class="title">{{ $workspace->name }}</h1>
  </div> -->
  <!-- <div class="columns is-centered">
    <p>{{ $workspace->description }}</p>
  </div> -->

  <!-- ELM INJECTION -->
  <div id="elm-main"></div>
  <script src="{{ asset('js/main.js') }}"></script>
  <script>
    let tabData = []
    @foreach ($workspace->tabs as $tab)
      tabData.push({
        id: {{ $tab->id }},
        name: "{{ $tab->name }}",
        url: "{{ $tab->url }}",
        uiid: "{{$loop->iteration}}"
      })
    @endforeach
    let app = Elm.Main.init({
      node: document.getElementById("elm-main"), 
      flags: { 
        tabs: tabData,
        workspaceId: {{ $workspace->id }},
        workspaceName: "{{ $workspace->name }}",
        workspacePrimaryColor: "{{ $workspace->icon_primary_color }}",
        csrfToken: "{{ csrf_token() }}"
      }
    })
    
    let tabs = []
    app.ports.openBrowserTabs.subscribe(function(data) {
      data.forEach(function(tab) {
        tabs.push(window.open(tab.url, '_blank'))
      })
      localStorage.setItem("{{ $workspace->name }}TabsOpen", true)
    });

    app.ports.closeBrowserTabs.subscribe(function(data) {
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

</section>
@endsection