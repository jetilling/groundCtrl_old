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
    let rawTaskData = []
    let highTaskData = []
    let moderateTaskData = []
    let lowTaskData = []
    let generalTaskData = []

    @foreach ($workspace->tabs as $tab)
      tabData.push({
        id: {{ $tab->id }},
        name: "{{ $tab->name }}",
        url: "{{ $tab->url }}",
        uiid: "{{$loop->iteration}}"
      })
    @endforeach

    @foreach ($workspace->tasks as $task)
      rawTaskData.push({
        id: {{ $task->id }},
        name: "{{ $task->name }}",
        completed: {{ $task->completed ? "true" : "false" }},
        priority: "{{ $task->priority }}",
        uiid: "{{$loop->iteration}}"
      })
    @endforeach

    rawTaskData.forEach(item => {
      switch (item.priority) {
        case "high":
          highTaskData.push(item)
          break;
        case "moderate":
          moderateTaskData.push(item)
          break;
        case "low":
          lowTaskData.push(item)
          break;
        case "general":
          generalTaskData.push(item)
          break;
      }
    })
    console.log(highTaskData, moderateTaskData)
    let app = Elm.Main.init({
      node: document.getElementById("elm-main"), 
      flags: { 
        tabs: tabData,
        highPriorityTasks: highTaskData,
        moderatePriorityTasks: moderateTaskData,
        lowPriorityTasks: lowTaskData,
        generalPriorityTasks: generalTaskData,
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