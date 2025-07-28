import logging
import sys
from datetime import datetime
from pathlib import Path

from prefect import flow, task


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

project_root = Path(__file__).parent.parent
sys.path.append(str(project_root))

@task(name="run-death-metal-pipeline")
def run_death_metal_pipeline():
    from scripts.apoena_pipeline import main

    logger.info("Executando pipeline dlt")
    pipeline = main()

    return {
        "pipeline_name": pipeline.pipeline_name,
        "destination": str(pipeline.destination),
        "dataset_name": pipeline.dataset_name,
        "status": "success",
        "timestamp": datetime.now().isoformat()
    }


@flow(name="Death Metal Workflow")
def death_metal_workflow():
    logger.info("Iniciando Death Metal Workflow")

    result = run_death_metal_pipeline()

    logger.info("Workflow concluído com sucesso")
    return result


if __name__ == "__main__":
    death_metal_workflow()