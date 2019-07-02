@extends('layouts.app')

@section('content')
<section class="light-background" style="padding-top: 50px;">
  <div class="columns is-centered">
    <h1 class="title">{{ $workspace->name }}</h1>
  </div>
  <div class="columns is-centered">
    <p>{{ $workspace->description }}</p>
  </div>

  <div class="tile is-ancestor">
    <div class="tile is-vertical is-8">
      <div class="tile">
        <div class="tile is-parent is-vertical">
          <article class="tile is-child notification is-primary">
            <p class="title">Vertical...</p>
            <p class="subtitle">Top tile</p>
          </article>
          <article class="tile is-child notification is-warning">
            <p class="title">...tiles</p>
            <p class="subtitle">Bottom tile</p>
          </article>
        </div>
        <div class="tile is-parent">
          <article class="tile is-child notification is-info">
            <p class="title">Middle tile</p>
            <p class="subtitle">With an image</p>
            <figure class="image is-4by3">
              <img src="https://bulma.io/images/placeholders/640x480.png">
            </figure>
          </article>
        </div>
      </div>
      <div class="tile is-parent">
        <article class="tile is-child notification is-danger">
          <p class="title">Wide tile</p>
          <p class="subtitle">Aligned with the right tile</p>
          <div class="content">
            <!-- Content -->
          </div>
        </article>
      </div>
    </div>
    <div class="tile is-parent">
      <article class="tile is-child notification is-success">
        <!-- <div class="content"> -->
          <!-- <div class="columns">
            <div class="column">
              <p class="title">Tabs</p>
            </div>
            <div class="column">
              <button class="button is-small">Add Tab</button>
            </div>
          </div>
          <p class="subtitle">Manage workspace specific browser tabs</p> -->
          <!-- <div class="content"> -->
            <!-- ELM INJECTION -->
            <div id="elm-tabs"></div>
            <script src="{{ asset('js/tabs.js') }}"></script>
            <script>
              Elm.Tabs.init({
                node: document.getElementById("elm-tabs"), 
                flags: { 
                  tabs: [],
                  workspaceId: {{ $workspace->id }} }
              })
            </script>
            <!-- <form method="POST" action="/home/workspaces/{{ $workspace->id }}/tab" class="box">

              @csrf
              <h4 class="title">New Tab</h4>

              <div class="field">
                <label class="label" for="description">Url</label>

                <div class="control">
                  <input type="text" class="input" name="url" placeholder="" required />
                </div>

              </div>

              <div class="field">
                <label class="label" for="description">Short Name</label>

                <div class="control">
                  <input type="text" class="input" name="name" placeholder="" required />
                </div>

              </div>

              <div class="field">
                <div class="control">
                  <button type="submit" class="button is-link">Add Tab</button>
                </div>
              </div>

              @include('errors')

            </form> -->
            @if ($workspace->tabs->count())
              <div>
                @foreach ($workspace->tabs as $tab)
                  <a href="{{ $tab->url }}">{{ $tab->name }}</a>
                @endforeach
              </div>
            @endif
          <!-- </div> -->
        <!-- </div> -->
      </article>
    </div>
  </div>

</section>
@endsection