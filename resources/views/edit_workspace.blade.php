@extends('layouts.app')

@section('content')
<section class="hero is-fullheight-with-navbar is-medium is-light" style="padding-top: 50px;">
  <div class="columns">
    <div class="column is-half is-offset-1">
    <h4 class="title is-4" style="color: rgb(54, 54, 54)">Edit a Workspace</h4>

      <form method="POST" action="/home/workspaces/{{ $workspace->id }}">
        @csrf
        @method("PATCH")

        <div class="field">
          <label class="label">Name</label>
          <div class="control">
            <input 
              class="input {{ $errors->has('name') ? 'is-danger' : '' }}" 
              type="text" 
              name="name" 
              placeholder="Workspace Name" 
              value="{{ $workspace->name }}">
          </div>
        </div>

        <div class="field">
          <label class="label">Description</label>
          <div class="control">
            <textarea class="textarea" name="description" placeholder="Workspace Description (optional)">{{ $workspace->description }}</textarea>
          </div>
        </div>

        <div class="field">
          <label class="label">Hourly Rate</label>
          <div class="control">
            <input 
              class="input {{ $errors->has('hourly_rate') ? 'is-danger' : '' }}" 
              type="text" 
              name="hourly_rate" 
              style="width: 20%"
              value="{{ $workspace->hourly_rate }}">
          </div>
        </div>

        <div class="field">
          <label class="label">Icon Colors</label>
          <div class="field is-grouped">
            <div class="control">
              <input class="input color-picker" type="color" name="icon_primary_color" placeholder="Primary Icon Color" value="{{ $workspace->icon_primary_color }}">
            </div>

            <div class="control">
              <input class="input color-picker" type="color" name="icon_secondary_color" placeholder="Secondary Icon Color" value="{{ $workspace->icon_secondary_color }}">
            </div>
          </div>
        </div>

        <div class="control">
            <button type="submit" class="button is-link">
                Save
            </button>
        </div>

        @include('errors')

      </form>
    </div>
  </div>
</section>



@endsection