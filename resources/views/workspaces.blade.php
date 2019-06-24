@extends('layouts.app')

@section('content')
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">Workspaces</div>

                    <div class="card-body">
                        These will be your workspaces

                        <a href="{{ route('workspaces.create') }}">Create a Workspace</a>
                    </div>

                    <div>
                        @foreach ($workspaces as $workspace)
                            <li><a href="/home/workspaces/{{$workspace->id}}">{{ $workspace->name }}</a> <a href="/home/workspace/{{ $workspace->id }}/edit">Edit</a></li>
                        @endforeach
                    </div>

                </div>
            </div>
        </div>
    </div>
</div>
@endsection
