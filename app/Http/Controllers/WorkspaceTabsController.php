<?php

namespace App\Http\Controllers;

use App\Tab;
use App\Workspace;
use Illuminate\Http\Request;

class WorkspaceTabsController extends Controller
{
     /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct()
    {
        $this->middleware('auth');
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

        $id = $workspace->addTab($attributes);

        return response()->json([
            'success' => true,
            'newItemId' => $id
        ]);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\WorkspaceTabs  $WorkspaceTabs
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, Tab $tab)
    {
        $attributes = request()->validate([
            'url' => 'required',
            'name' => 'required'
        ]);

        $tab->update($attributes);

        return response()->json([
            'success' => true
        ]);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\WorkspaceTabs  $WorkspaceTabs
     * @return \Illuminate\Http\Response
     */
    public function destroy(Tab $tab)
    {
        $tab->delete();

        return response()->json([
            'success' => true
        ]);
    }


}
