<?php

namespace App\Http\Controllers;

use App\Tab;
use App\Workspace;
use Illuminate\Http\Request;

class WorkspaceTabsController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        //
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Workspace $workspace)
    {
        $attributes = request()->validate([
            'url' => 'required',
            'name' => 'required'
        ]);

        $workspace->addTab($attributes);

        // return back();
        return response()->json([
            'success' => true
        ]);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\WokrspaceTabs  $wokrspaceTabs
     * @return \Illuminate\Http\Response
     */
    public function show(WokrspaceTabs $wokrspaceTabs)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\WokrspaceTabs  $wokrspaceTabs
     * @return \Illuminate\Http\Response
     */
    public function edit(WokrspaceTabs $wokrspaceTabs)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\WokrspaceTabs  $wokrspaceTabs
     * @return \Illuminate\Http\Response
     */
    public function update(Tab $tab)
    {
        $method = request()->has('completed') ? 'complete' : 'incomplete';

        $task->$method();

        return back();
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\WokrspaceTabs  $wokrspaceTabs
     * @return \Illuminate\Http\Response
     */
    public function destroy(WokrspaceTabs $wokrspaceTabs)
    {
        //
    }


}
