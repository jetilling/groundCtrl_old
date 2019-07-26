<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class Task extends Model
{
    protected $guarded = ['id'];

    public function workspace()
    {
        return $this->belongsTo(Workspace::class);
    }
}
