<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class Workspace extends Model
{

    // These fields are not allowed to be mass assigned in the controller
    protected $guarded = [
        'id'
    ];

    // TABS

    public function tabs ()
    {
        return $this->hasMany(Tab::class);
    }

    public function addTab($tab)
    {
        return $this->tabs()->create($tab)->id;
    }

    // NOTES

    public function notes ()
    {
        return $this->hasMany(Notes::class);
    }

    public function addNote($note)
    {
        $this->notes()->create($note);
    }

    // TASKS

    public function tasks ()
    {
        return $this->hasMany(Task::class);
    }

    public function addTask($task)
    {
        $this->tasks()->create($task);
    }
}
