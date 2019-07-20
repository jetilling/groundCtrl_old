@extends('layouts.app')

@section('content')
<section class="hero is-fullheight-with-navbar is-medium is-light">
    <div class="hero-body">
        <div class="container">
            <div class="columns is-centered">
                <article class="box">
                    <div class="media-content">

                        <h4 class="title is-4" style="color: rgb(54, 54, 54)">{{ __('Register') }}</h4>

                        <form method="POST" action="{{ route('register') }}">
                            @csrf

                            <div class="field">
                                <label for="name" class="label">{{ __('Name') }}</label>

                                <div class="col-md-6">
                                    <input id="name" type="text" class="input @error('name') is-invalid @enderror" name="name" value="{{ old('name') }}" required autocomplete="name" autofocus>

                                    @error('name')
                                        <span class="invalid-feedback" role="alert">
                                            <strong>{{ $message }}</strong>
                                        </span>
                                    @enderror
                                </div>
                            </div>

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
                                <label for="password-confirm" class="label">{{ __('Confirm Password') }}</label>

                                <div class="col-md-6">
                                    <input id="password-confirm" type="password" class="input" name="password_confirmation" required autocomplete="new-password">
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
                                        {{ __('Register') }}
                                    </button>
                                </div>

                            </div>
                        </form>
                    </div>
                </article>
            </div>
        </div>
    </div>
</section>
@endsection
