from prefect import flow, task


@task(name='task_inicial')
def init_task():
    from workflows.scripts.apoena_pipeline import main
    return main()


@flow(name='task_flow')
def run_pipeline():
    return init_task()


if __name__ == "__main__":
    run_pipeline()
