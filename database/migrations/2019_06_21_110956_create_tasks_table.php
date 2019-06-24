<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateTasksTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        $priorities = ['low', 'medium', 'high', 'urgent'];

        Schema::create('tasks', function (Blueprint $table) use ($priorities) {
            $table->bigIncrements('id');
            $table->unsignedInteger('workspace_id');
            $table->string('description');
            $table->boolean('completed')->default(false);
            $table->enum('priority', $priorities);
            $table->dateTimeTz('due');
            $table->timestamps();

            $table->foreign('workspace_id')->references('id')->on('workspaces');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('tasks');
    }
}
