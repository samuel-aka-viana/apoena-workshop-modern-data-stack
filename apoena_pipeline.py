import logging
from typing import Iterator, Dict, Any

import dlt
from dlt.sources.filesystem import filesystem, read_csv

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

BUCKET_URL = "gs://death-metal-raw-data"


@dlt.source(name="death_metal_data")
def death_metal_source():
    @dlt.resource(
        name="metal_bands",
        write_disposition="replace"
    )
    def load_metal_bands() -> Iterator[Dict[str, Any]]:
        source = filesystem(
            bucket_url=f'{BUCKET_URL}/bands',
            file_glob="*.csv"
        ) | read_csv()

        for row in source:
            yield row

    @dlt.resource(
        name="metal_albums",
        write_disposition="replace",
        primary_key="id"
    )
    def load_metal_albums() -> Iterator[Dict[str, Any]]:
        source = filesystem(
            bucket_url=f'{BUCKET_URL}/albums',
            file_glob="*.csv"
        ) | read_csv()

        for row in source:
            yield row

    @dlt.resource(
        name="metal_reviews",
        write_disposition="replace",
        primary_key="id"
    )
    def load_metal_reviews() -> Iterator[Dict[str, Any]]:
        source = filesystem(
            bucket_url=f'{BUCKET_URL}/reviews',
            file_glob="*.csv"
        ) | read_csv()

        for row in source:
            yield row

    return load_metal_bands(), load_metal_albums(), load_metal_reviews()


def main():
    pipeline = dlt.pipeline(
        pipeline_name="death_metal_pipeline",
        destination="bigquery",
        dataset_name="metal_data",
        progress="tqdm",
        dev_mode=False
    )

    logger.info("Iniciando carregamento dos dados do GCS")
    load_info = pipeline.run(
        data=death_metal_source(),
        write_disposition="replace"
    )

    print(f"Load info: {load_info}")

    try:
        df = pipeline.dataset(dataset_type="default").metal_bands.df()
        print(pipeline.dataset(dataset_type="default").metal_albums.df())
        print(pipeline.dataset(dataset_type="default").metal_reviews.df())

        print(f"Total de registros: {len(df)}")
        print(f"Total de registros: {len(pipeline.dataset(dataset_type="default").metal_albums.df())}")
        print(f"Total de registros: {len(pipeline.dataset(dataset_type="default").metal_reviews.df())}")
        print(f"IDs únicos: {df['id'].nunique()}")

        print("Primeiras linhas:")
        print(df.head())

    except Exception as e:
        logger.error(f"Erro na validação dos dados: {e}")
        logger.info("Os dados foram carregados, mas a validação falhou")

    return pipeline


if __name__ == "__main__":
    try:
        pipeline = main()
        print(" Processo concluído com sucesso!")
        print(f" Pipeline: {pipeline.pipeline_name}")
        print(f" Destino: {pipeline.destination}")
        print(f" Dataset: {pipeline.dataset_name}")

    except Exception as e:
        logger.error(f" Erro na execução do pipeline: {e}")
        raise
