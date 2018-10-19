import numpy as np
from trainer.model import generate_recommendations

client_id = 1000163602560555666
already_rated = [295436355, 295044773, 295195092]
k = 5
user_map = np.load("your-model-location/user.npy")
item_map = np.load("your-model-location/model/item.npy")
row_factor = np.load("your-model-location/model/row.npy")
col_factor = np.load("your-model-location/model/col.npy")
user_idx = np.searchsorted(user_map, client_id)
user_rated = [np.searchsorted(item_map, i) for i in already_rated]

recommendations = generate_recommendations(user_idx, user_rated, row_factor, col_factor, k)

article_recommendations = [item_map[i] for i in recommendations]

print article_recommendations
