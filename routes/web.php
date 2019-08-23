<?php

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/
Route::get('/', function () {
  return view('landing');
});

Auth::routes();

Route::prefix('home')->group(function () {

  Route::get('/', 'HomeController@index')->name('home');
  Route::resource('workspaces', 'WorkspaceController');

  Route::post('/workspaces/{workspace}/tab', 'WorkspaceTabsController@store');
  Route::put('/tabs/{tab}', 'WorkspaceTabsController@update');
  Route::delete('/tabs/{tab}', 'WorkspaceTabsController@destroy');

  Route::post('/workspaces/{workspace}/task', 'WorkspaceTasksController@store');
  Route::put('/tasks/{task}', 'WorkspaceTasksController@update');
  Route::put('/tasks/{task}/update-complete', 'WorkspaceTasksController@updateComplete');
  Route::delete('/tasks/{task}', 'WorkspaceTasksController@destroy');

  Route::get('payment_calculator', 'PaymentCalculator@index')->name('payment_calculator');
});
