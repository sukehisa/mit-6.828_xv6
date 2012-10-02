#include <inc/assert.h>

#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/monitor.h>


// Choose a user environment to run and run it.
void
sched_yield(void)
{
	struct Env *idle;
	int i;

	// Implement simple round-robin scheduling.
	//
	// Search through 'envs' for an ENV_RUNNABLE environment in
	// circular fashion starting just after the env this CPU was
	// last running.  Switch to the first such environment found.
	//
	// If no envs are runnable, but the environment previously
	// running on this CPU is still ENV_RUNNING, it's okay to
	// choose that environment.
	//
	// Never choose an environment that's currently running on
	// another CPU (env_status == ENV_RUNNING) and never choose an
	// idle environment (env_type == ENV_TYPE_IDLE).  If there are
	// no runnable environments, simply drop through to the code
	// below to switch to this CPU's idle environment.

	// LAB 4: Your code here.
	// Env, Cpu
	int id;
	struct Env *next = NULL;
	int current_index = (curenv == NULL) ? 0 : curenv - envs;
	current_index++;
	for (i = 0; i < NENV; i++) {
		id = (current_index + i) % NENV;
		if (envs[id].env_type != ENV_TYPE_IDLE && envs[id].env_status != ENV_RUNNING &&
				envs[id].env_status == ENV_RUNNABLE) {
			next = &envs[id];
			break;
		}
	}
	if (curenv != NULL) {
		if (next == NULL && curenv->env_status == ENV_RUNNING && 
				curenv->env_type != ENV_TYPE_IDLE) {
			next = curenv;
		}
	}
	if (next != NULL) {
		env_run(next);
	}

	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	if (next == NULL) {
		cprintf("No more runnable environments!\n");
		while (1)
			monitor(NULL);
	}

	// Run this CPU's idle environment when nothing else is runnable.
	idle = &envs[cpunum()];
	if (!(idle->env_status == ENV_RUNNABLE || idle->env_status == ENV_RUNNING))
		panic("CPU %d: No idle environment!", cpunum());
	env_run(idle);
}
