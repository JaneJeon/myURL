const { tableName } = require('../models/link')

exports.up = knex =>
  knex.schema.createTable(tableName, table => {
    table.increments()
    table.text('hash').unique()
    table
      .text('originalURL')
      .notNullable()
      .unique()
    table
      .text('creatorId')
      .references('users.id')
      .notNullable()

    table.jsonb('meta')

    table.timestamps(true, true)
  })

exports.down = knex => knex.schema.dropTable(tableName)