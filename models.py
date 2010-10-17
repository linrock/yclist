from elixir import *


class Company(Entity):
    using_table_options(useexisting=True)
    using_options(tablename='companies')

    has_field('name',           String(32), index=True)
    has_field('class_year',     String(128))
    has_field('url',            String(128))
    has_field('title',          String(128))
    has_field('meta_desc',      String(128))
    has_field('dead',           Boolean)
    has_field('exited',         Boolean)

    has_field('favicon_path',   String(128))
    has_field('snapshot_path',  String(128))


metadata.bind = 'sqlite:///data.sqlite'
metadata.bind.echo = False
setup_all(True)
