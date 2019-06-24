@extends('layouts.app')

@section('content')
<section class="hero is-fullheight-with-navbar is-medium is-primary is-bold">
    <div class="hero-body">
        <div class="container">
            <div class="columns is-centered">
                <article class="box">
                    <div class="media-content">

                        <h4 class="title is-4" style="color: rgb(54, 54, 54)">{{ __('Login') }}</h4>

                        <form method="POST" action="{{ route('login') }}">
                            @csrf

                            <div class="field">
                                <label for="email" class="label">{{ __('E-Mail Address') }}</label>

                                <div class="control">
                                    <input id="email" type="email" class="input @error('email') is-invalid @enderror" name="email" value="{{ old('email') }}" required autocomplete="email" autofocus>

                                    @error('email')
                                        <span class="invalid-feedback" role="alert">
                                            <strong>{{ $message }}</strong>
                                        </span>
                                    @enderror
                                </div>
                            </div>

                            <div class="field">
                                <label for="password" class="label">{{ __('Password') }}</label>

                                <div class="control">
                                    <input id="password" type="password" class="input @error('password') is-invalid @enderror" name="password" required autocomplete="current-password">

                                    @error('password')
                                        <span class="invalid-feedback" role="alert">
                                            <strong>{{ $message }}</strong>
                                        </span>
                                    @enderror
                                </div>
                            </div>

                            <div class="field">
                                <div class="control">
                                    <label class="checkbox" for="remember">
                                        <input class="form-check-input" type="checkbox" name="remember" id="remember" {{ old('remember') ? 'checked' : '' }}>
                                        {{ __('Remember Me') }}
                                    </label>
                                </div>
                            </div>


                            <div class="field is-grouped">
                                <div class="control">
                                    <button type="submit" class="button is-link">
                                        {{ __('Login') }}
                                    </button>
                                </div>

                                @if (Route::has('password.request'))
                                    <div class="control center-vertical">
                                        <a class="btn btn-link" href="{{ route('password.request') }}">
                                            {{ __('Forgot Your Password?') }}
                                        </a>
                                    </div>
                                @endif
                            </div>
                        </form>
                    </div>
                </article>
            </div>
        </div>
    </div>
</section>
@endsection
