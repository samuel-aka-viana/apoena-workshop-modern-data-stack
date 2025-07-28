from prefect import flow, task
from prefect_dbt import DbtCoreOperation
from pathlib import Path


@task
def validate_dbt_setup():
    project_dir = Path("../dbt_apoena")
    if not project_dir.exists():
        raise FileNotFoundError(f"dbt project não encontrado: {project_dir}")
    return str(project_dir)


@task
def dbt_deps(project_dir: str):
    dbt_op = DbtCoreOperation(
        commands=["dbt deps"],
        project_dir=project_dir,
        profiles_dir="~/.dbt"
    )
    return dbt_op.run()


@task
def dbt_run(project_dir: str, select: str = None):
    commands = ["dbt run"]
    if select:
        commands = [f"dbt run"]

    dbt_op = DbtCoreOperation(
        commands=commands,
        project_dir=project_dir,
        profiles_dir="~/.dbt"
    )
    return dbt_op.run()


@task
def dbt_test(project_dir: str):
    dbt_op = DbtCoreOperation(
        commands=["dbt test"],
        project_dir=project_dir,
        profiles_dir="~/.dbt"
    )
    return dbt_op.run()


@flow(name="Death Metal dbt Pipeline")
def death_metal_dbt_flow():
    project_dir = validate_dbt_setup()

    dbt_deps(project_dir)

    dbt_run(project_dir, select="staging")
    dbt_run(project_dir, select="intermediate")
    dbt_run(project_dir, select="marts")

    dbt_test(project_dir)

    return "Pipeline dbt concluído com sucesso!"