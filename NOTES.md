I'm thinking I should provide a default serializer for a skill tree as such:

```json
{
    "nodes": {
        "0": null,
        "1": null,
        "2": null,
        "3": null,
        "4": null,
        "5": null,
        "6": null
    },
    "edges": {
        "0-1": null,
        "2-5": null,
        "1-3": null
    },
    "layout": [
        [
            "0",
            "1",
            null
        ],
        [
            "2",
            null,
            "3"
        ],
        [
            "4",
            "5",
            "6"
        ]
    ]
}
```