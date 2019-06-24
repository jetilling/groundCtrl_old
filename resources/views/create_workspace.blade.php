@extends('layouts.app')

@section('content')
<section class="hero is-fullheight-with-navbar is-medium is-light" style="padding-top: 50px;">
  <div class="columns">
    <div class="column is-half is-offset-1">
    <h4 class="title is-4" style="color: rgb(54, 54, 54)">Create a Workspace</h4>

      <form method="POST" action="/workspaces">
        @csrf

        <div class="field">
          <label class="label">Name</label>
          <div class="control">
            <input class="input {{ $errors->has('name') ? 'is-danger' : '' }}" type="text" name="name" placeholder="Workspace Name" value="{{ old('name') }}">
          </div>
        </div>

        <div class="field">
          <label class="label">Description</label>
          <div class="control">
            <textarea class="textarea" name="description" placeholder="Workspace Description (optional)"></textarea>
          </div>
        </div>

        <div class="field">
          <label class="label">Icon Colors</label>
          <div class="field is-grouped">
            <div class="control">
              <input class="input color-picker" type="color" name="primary_icon_color" placeholder="Primary Icon Color">
            </div>

            <div class="control">
              <input class="input color-picker" type="color" name="secondary_icon_color" placeholder="Secondary Icon Color">
            </div>
          </div>
        </div>

        <div class="control">
            <button type="submit" class="button is-link">
                Create
            </button>
        </div>

        @include('errors')

      </form>
    </div>
  </div>
</section>



@endsection