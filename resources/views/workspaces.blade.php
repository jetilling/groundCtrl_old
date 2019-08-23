@extends('layouts.app')

@section('content')
<section class="hero is-fullheight-with-navbar is-medium is-light" style="padding-top: 50px;">
    <div class="columns is-centered">
        <h2 class="title">Workspaces</h2>
    </div>
    <div class="columns is-centered">
        <a href="{{ route('workspaces.create') }}">Create a Workspace</a>
    </div>
    <div class="container is-fluid" style="padding-top: 30px;">
        <div class="columns is-multiline">

            @foreach ($workspaces as $workspace)
                <div class="column is-one-quarter">
                    <div class="box set-box-heights">
                        <article class="media">
                            <div class="media-left">
                                <figure class="image is-64x64">
                                    <div class="workspace-icon" style="background-image: linear-gradient({{ $workspace->icon_primary_color }}, {{ $workspace->icon_secondary_color }});"></div>
                                </figure>
                            </div>
                            <div class="media-content">
                                <div class="content">
                                    <p>
                                        <strong><a href="/home/workspaces/{{$workspace->id}}">{{ $workspace->name }}</a></strong> <small><a href="/home/workspaces/{{ $workspace->id }}/edit">Edit</a></small>
                                        <br>
                                        {{ $workspace->description }}
                                    </p>
                                </div>
                            </div>
                        </article>
                    </div>
                </div>
            @endforeach
                    
        </div>
    </div>
</section>
@endsection
