<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use \App\Workspace;

class WorkspaceController extends Controller
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
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {

        $workspaces = Workspace::all();

        return view('workspaces', compact('workspaces'));
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create()
    {
        return view('create_workspace');
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        request()->validate([
            'name' => ['required', 'min:3'],
            'description' => 'required',
            'icon_primary_color' => 'required',
            'icon_secondary_color' => 'required'
        ]);

        Workspace::create([
            'name' => request('name'),
            'description' => request('description'),
            'icon_primary_color' => request('icon_primary_color'),
            'icon_secondary_color' => request('icon_secondary_color'),
            'user_id' => Auth::id()
        ]);

        return redirect('/home/workspaces');
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show(Workspace $workspace)
    {
        // $tabs = array();
        // foreach ($workspace->tabs as $tab) {
        //     array_push($tabs, [
        //         'id' => $tab->id, 
        //         'name' => $tab->name,
        //         'url' => $tab->url]);
        // }
        // $workspace->tabs = $tabs;
        // dd($workspace->tasks);
        return view('workspace_dash', compact('workspace'));
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function edit($id)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $id)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy($id)
    {
        //
    }
}
