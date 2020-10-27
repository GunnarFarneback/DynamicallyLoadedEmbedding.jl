#ifndef _JULIA_EMBEDDING_H_
#define _JULIA_EMBEDDING_H_

const char *julia_preinitialize();
int julia_initialize(const char *julia_loader_filename,
                     const char *julia_system_image_path);
int julia_eval_string(const char *command, const char *error_message);
void *get_cfunction_pointer(const char *name);
int julia_exit(int);

#endif
