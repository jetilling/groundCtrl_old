@extends('layouts.app')

@section('content')
<section class="hero is-fullheight-with-navbar is-medium is-light" style="padding-top: 50px;">
    <div class="columns is-centered">
        <h2 class="title">Calculator</h2>
    </div>
    <div class="columns is-centered">
        
    </div>
    <div class="container is-fluid" style="padding-top: 30px;">
      <div id="root"></div>
      <script>
        window.workspaces = {!! $workspaces !!};
      </script>
      <script src="{{ mix('js/index.js') }}"></script>
    </div>
</section>
@endsection