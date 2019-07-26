<?php

namespace App\Http\Controllers;

use App\Task;
use App\Workspace;
use Illuminate\Http\Request;

class WorkspaceTasksController extends Controller
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
            'priority' => 'required',
            'name' => 'required'
        ]);

        $id = $workspace->addTask($attributes);

        return response()->json([
            'success' => true,
            'newItemId' => $id
        ]);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\WorkspaceTasks  $WorkspaceTasks
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, Task $task)
    {
        $attributes = request()->validate([
            'priority' => 'required',
            'name' => 'required'
        ]);

        $task->update($attributes);

        return response()->json([
            'success' => true
        ]);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\WorkspaceTasms  $WorkspaceTasks
     * @return \Illuminate\Http\Response
     */
    public function destroy(Task $task)
    {
        $task->delete();

        return response()->json([
            'success' => true
        ]);
    }
}
